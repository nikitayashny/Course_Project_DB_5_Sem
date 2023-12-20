const fs = require('fs');
const oracledb = require('oracledb');

const config = {
    user: 'SYSTEM',
    password: '123',
    connectString: '//localhost:1521/CP_YNS_PDB'
};

async function exportDataFromJson() {
  try {
    const jsonData = fs.readFileSync('input.json', 'utf8');
    const products = JSON.parse(jsonData);
   
    const connection = await oracledb.getConnection(config);

    const value = await connection.execute('SELECT max(product_id) FROM products');
    let id = value.rows[0][0];

    for (const product of products) {
       const { product_name, category_id, price, description, image_url, quantity } = product;
        id += 1;
       const insertQuery = `
         INSERT INTO products
         VALUES (:product_id, :product_name, :category_id, :price, :description, :image_url, :quantity)
       `;

      const bindParams = {
        product_id: id,
        product_name: product_name,
        category_id: category_id,
        price: price,
        description: description,
        image_url: image_url,
        quantity: quantity,
      };

      await connection.execute(insertQuery, bindParams);
    }
    await connection.execute("commit");
    console.log('Exporting data to the Oracle database completed.');

    await connection.close();
  } catch (error) {
    console.error('Error exporting data:', error);
  }
}

exportDataFromJson();