import { useEffect, useState } from 'react';
import { Alert, Card, CardContent, CircularProgress, Container, Stack, Typography } from '@mui/material';
import { tokenStorage } from '../../../security/token-storage';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';

type AuditLog = {
  id: number;
  actorEmail: string | null;
  action: string;
  resourceType: string;
  resourceId: string | null;
  details: string | null;
  createdAt: string;
};

export default function AdminAuditLogsPage() {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadAuditLogs() {
      try {
        const response = await fetch(`${API_BASE_URL}/api/audit/logs`, { headers: tokenStorage.authHeader() });
        if (!response.ok) throw new Error(`Audit logs endpoint returned ${response.status}`);
        setLogs(await response.json());
      } catch (err: any) {
        setError(err.message || 'Audit logs could not be loaded.');
      } finally {
        setLoading(false);
      }
    }
    loadAuditLogs();
  }, []);

  return (
    <Container maxWidth="xl">
      <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 3 }}>
        <CardContent>
          <Stack spacing={2}>
            <Typography variant="h5" sx={{ fontWeight: 900 }}>Audit Logs</Typography>
            {loading && <CircularProgress />}
            {error && <Alert severity="error">{error}</Alert>}
            {!loading && !error && logs.length === 0 && <Alert severity="info">No audit logs yet.</Alert>}
            {logs.map((log) => (
              <Card key={log.id} variant="outlined">
                <CardContent>
                  <Typography sx={{ fontWeight: 900 }}>{log.action} · {log.resourceType}</Typography>
                  <Typography color="text.secondary">
                    {log.actorEmail ?? 'system'} · {new Date(log.createdAt).toLocaleString()}
                  </Typography>
                  {log.details && <Typography sx={{ mt: 1 }}>{log.details}</Typography>}
                </CardContent>
              </Card>
            ))}
          </Stack>
        </CardContent>
      </Card>
    </Container>
  );
}
