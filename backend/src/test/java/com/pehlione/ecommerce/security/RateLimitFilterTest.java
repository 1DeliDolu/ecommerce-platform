package com.pehlione.ecommerce.security;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.http.HttpStatus;
import jakarta.servlet.FilterChain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class RateLimitFilterTest {

    private final RateLimitFilter filter = new RateLimitFilter();

    @Test
    void allowsRequestsUnderLimit() throws Exception {
        MockHttpServletRequest request = requestFor("/api/products");
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain chain = mock(FilterChain.class);

        filter.doFilterInternal(request, response, chain);

        verify(chain, times(1)).doFilter(request, response);
        assertThat(response.getStatus()).isEqualTo(HttpStatus.OK.value());
    }

    @Test
    void blocksAuthRequestsAfterLimit() throws Exception {
        FilterChain chain = mock(FilterChain.class);

        // Exhaust the auth limit
        for (int i = 0; i < RateLimitFilter.AUTH_MAX_REQUESTS; i++) {
            MockHttpServletRequest req = requestFor("/api/auth/login");
            MockHttpServletResponse res = new MockHttpServletResponse();
            filter.doFilterInternal(req, res, chain);
        }

        // Next request should be rate-limited
        MockHttpServletRequest req = requestFor("/api/auth/login");
        MockHttpServletResponse res = new MockHttpServletResponse();
        filter.doFilterInternal(req, res, chain);

        assertThat(res.getStatus()).isEqualTo(HttpStatus.TOO_MANY_REQUESTS.value());
    }

    @Test
    void resolveClientIpUsesXForwardedForHeader() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("X-Forwarded-For", "203.0.113.1, 10.0.0.1");

        String ip = RateLimitFilter.resolveClientIp(request);

        assertThat(ip).isEqualTo("203.0.113.1");
    }

    @Test
    void resolveClientIpFallsBackToRemoteAddr() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setRemoteAddr("192.168.1.100");

        String ip = RateLimitFilter.resolveClientIp(request);

        assertThat(ip).isEqualTo("192.168.1.100");
    }

    private MockHttpServletRequest requestFor(String path) {
        MockHttpServletRequest req = new MockHttpServletRequest();
        req.setRequestURI(path);
        req.setRemoteAddr("127.0.0.1");
        return req;
    }
}
