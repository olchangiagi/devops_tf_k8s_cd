// 본격적인 HPA 테스트 전에 URL과 응답 상태를 빠르게 확인하는 k6 Smoke Test이다.
import http from 'k6/http';
import { check, sleep } from 'k6';

const targetUrl = __ENV.TARGET_URL;

if (!targetUrl) {
  throw new Error('TARGET_URL 환경변수가 필요합니다.');
}

export const options = {
  // 사용자 1명이 10초 동안 가볍게 요청한다.
  vus: 1,
  duration: '10s',
  thresholds: {
    http_req_failed: ['rate==0'],
  },
};

export default function () {
  const response = http.get(targetUrl, { timeout: '10s' });

  check(response, {
    'HTTP status is 2xx': (r) => r.status >= 200 && r.status < 300,
  });

  sleep(1);
}
