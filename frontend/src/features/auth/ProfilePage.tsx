import { Box, Card, CardContent, Chip, Container, Stack, Typography } from '@mui/material';
import { useAuth } from './AuthContext';

export default function ProfilePage() {
  const auth = useAuth();

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 5 }}>
      <Container maxWidth="md">
        <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider' }}>
          <CardContent sx={{ p: { xs: 3, md: 5 } }}>
            <Typography variant="h4" sx={{ fontWeight: 900 }} gutterBottom>
              Profile
            </Typography>
            <Stack spacing={2}>
              <Typography><strong>Name:</strong> {auth.user?.fullName}</Typography>
              <Typography><strong>Email:</strong> {auth.user?.email}</Typography>
              <Typography><strong>Role:</strong> {auth.user?.role}</Typography>
              <Stack direction="row" spacing={1} sx={{ flexWrap: 'wrap', gap: 1 }}>
                {auth.user?.permissions.map((permission) => (
                  <Chip key={permission} label={permission} size="small" />
                ))}
              </Stack>
            </Stack>
          </CardContent>
        </Card>
      </Container>
    </Box>
  );
}
