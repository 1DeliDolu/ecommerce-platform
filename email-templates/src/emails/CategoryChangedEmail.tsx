import * as React from 'react';
import {
  Body,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from 'react-email';

type CategoryChangedEmailProps = {
  action: 'CREATED' | 'UPDATED' | 'DELETED';
  categoryName: string;
  slug: string;
  status?: string;
  productCount?: string;
};

export default function CategoryChangedEmail({
  action = 'UPDATED',
  categoryName = 'Demo Category',
  slug = 'demo-category',
  status = 'ACTIVE',
  productCount = '0',
}: CategoryChangedEmailProps) {
  return (
    <Html lang="en">
      <Head />
      <Preview>Category {action.toLowerCase()}: {categoryName}</Preview>

      <Body style={styles.body}>
        <Container style={styles.container}>
          <Section style={styles.header}>
            <Heading style={styles.title}>Category {action}</Heading>
            <Text style={styles.subtitle}>Admin notification</Text>
          </Section>

          <Section style={styles.content}>
            <Text style={styles.text}>
              A category has been <strong>{action.toLowerCase()}</strong>.
            </Text>

            <Section style={styles.summaryBox}>
              <Text style={styles.summaryLine}>
                <strong>Category:</strong> {categoryName}
              </Text>
              <Text style={styles.summaryLine}>
                <strong>Slug:</strong> {slug}
              </Text>
              {action !== 'DELETED' && (
                <>
                  <Text style={styles.summaryLine}>
                    <strong>Status:</strong> {status}
                  </Text>
                  <Text style={styles.summaryLine}>
                    <strong>Product Count:</strong> {productCount}
                  </Text>
                </>
              )}
            </Section>
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
    backgroundColor: '#0f172a',
    padding: '28px 32px',
  },
  title: {
    color: '#ffffff',
    fontSize: '24px',
    margin: '0',
  },
  subtitle: {
    color: '#facc15',
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
} as const;
