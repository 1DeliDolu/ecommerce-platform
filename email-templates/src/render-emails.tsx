import * as React from 'react';
import { mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pretty, render } from 'react-email';

import OrderConfirmationEmail from './emails/OrderConfirmationEmail.js';
import ProductChangedEmail from './emails/ProductChangedEmail.js';
import CategoryChangedEmail from './emails/CategoryChangedEmail.js';

const outputDir = resolve(process.cwd(), 'dist/generated');

async function renderTemplate(fileName: string, element: React.ReactElement) {
  const html = await pretty(await render(element));
  await writeFile(resolve(outputDir, fileName), html, 'utf8');
  console.log(`Generated ${fileName}`);
}

async function main() {
  await mkdir(outputDir, { recursive: true });

  await renderTemplate(
    'order-confirmation.html',
    <OrderConfirmationEmail
      customerName="{{customerName}}"
      orderNumber="{{orderNumber}}"
      status="{{status}}"
      totalAmount="{{totalAmount}}"
      items={[
        {
          name: '{{itemSummary}}',
          quantity: 1,
          unitPrice: '{{subtotal}}',
          lineTotal: '{{subtotal}}',
        },
      ]}
    />
  );

  await renderTemplate(
    'product-created.html',
    <ProductChangedEmail
      action="CREATED"
      productName="{{productName}}"
      categoryName="{{categoryName}}"
      price="{{price}}"
      stockQuantity="{{stockQuantity}}"
      slug="{{slug}}"
    />
  );

  await renderTemplate(
    'product-updated.html',
    <ProductChangedEmail
      action="UPDATED"
      productName="{{productName}}"
      categoryName="{{categoryName}}"
      price="{{price}}"
      stockQuantity="{{stockQuantity}}"
      slug="{{slug}}"
    />
  );

  await renderTemplate(
    'product-deleted.html',
    <ProductChangedEmail
      action="DELETED"
      productName="{{productName}}"
      categoryName="{{categoryName}}"
      slug="{{slug}}"
    />
  );

  await renderTemplate(
    'category-created.html',
    <CategoryChangedEmail
      action="CREATED"
      categoryName="{{categoryName}}"
      slug="{{slug}}"
      status="{{status}}"
      productCount="{{productCount}}"
    />
  );

  await renderTemplate(
    'category-updated.html',
    <CategoryChangedEmail
      action="UPDATED"
      categoryName="{{categoryName}}"
      slug="{{slug}}"
      status="{{status}}"
      productCount="{{productCount}}"
    />
  );

  await renderTemplate(
    'category-deleted.html',
    <CategoryChangedEmail
      action="DELETED"
      categoryName="{{categoryName}}"
      slug="{{slug}}"
    />
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
