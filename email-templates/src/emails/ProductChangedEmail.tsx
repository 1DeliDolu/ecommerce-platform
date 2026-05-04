import * as React from 'react';
import {
  Body,
  Container,
  Head,
  Heading,
  Hr,
  Html,
  Preview,
  Section,
  Text,
} from 'react-email';

type ProductChangedEmailProps = {
  action: 'CREATED' | 'UPDATED' | 'DELETED';
  productName: string;
  categoryName: string;
  price?: string;
  stockQuantity?: string;
  slug: string;
};

export default function ProductChangedEmail({
  action = 'UPDATED',
  productName = 'Demo Product',
  categoryName = 'Demo Category',
  price = '0.00',
  stockQuantity = '0',
  slug = 'demo-product',
}: ProductChangedEmailProps) {
  return (
    <Html lang="en">
      <Head />
      <Preview>Product {action.toLowerCase()}: {productName}</Preview>

      <Body style={styles.body}>
        <Container style={styles.container}>
          <Section style={styles.header}>
            <Heading style={styles.title}>Product {action}</Heading>
            <Text style={styles.subtitle}>Admin notification</Text>
          </Section>

          <Section style={styles.content}>
            <Text style={styles.text}>
              A product has been <strong>{action.toLowerCase()}</strong>.
            </Text>

            <Section style={styles.summaryBox}>
              <Text style={styles.summaryLine}>
                <strong>Product:</strong> {productName}
              </Text>
              <Text style={styles.summaryLine}>
                <strong>Category:</strong> {categoryName}
              </Text>
              <Text style={styles.summaryLine}>
                <strong>Slug:</strong> {slug}
              </Text>
              {action !== 'DELETED' && (
                <>
                  <Text style={styles.summaryLine}>
                    <strong>Price:</strong> €{price}
                  </Text>
                  <Text style={styles.summaryLine}>
                    <strong>Stock:</strong> {stockQuantity}
                  </Text>
                </>
              )}
            </Section>

            <Hr style={styles.hr} />

            <Text style={styles.footerText}>
              Check the admin product panel for details.
            </Text>
          </Section>
        </Container>
      </Body>
    </Html>
  );
}

const styles = {
  body: {
    backgroundColor: '#f5f7fb',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
    padding: '24px',
  },
  container: {
    backgroundColor: '#ffffff',
    borderRadius: '18px',
    maxWidth: '620px',
    margin: '0 auto',
    overflow: 'hidden',
    border: '1px solid #e5e7eb',
  },
  header: {
    backgroundColor: '#111827',
    padding: '28px 32px',
  },
  title: {
    color: '#ffffff',
    fontSize: '24px',
    margin: '0',
  },
  subtitle: {
    color: '#93c5fd',
    fontSize: '14px',
    margin: '8px 0 0',
  },
  content: {
    padding: '32px',
  },
  text: {
    color: '#374151',
    fontSize: '15px',
    lineHeight: '24px',
  },
  summaryBox: {
    backgroundColor: '#f8fafc',
    border: '1px solid #e5e7eb',
    borderRadius: '14px',
    padding: '18px',
    margin: '24px 0',
  },
  summaryLine: {
    color: '#111827',
    fontSize: '15px',
    margin: '6px 0',
  },
  hr: {
    borderColor: '#e5e7eb',
    margin: '24px 0',
  },
  footerText: {
    color: '#6b7280',
    fontSize: '13px',
  },
} as const;
