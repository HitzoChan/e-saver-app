const https = require('https');

const options = {
  hostname: 'graph.facebook.com',
  port: 443,
  path: '/v18.0/117290636838993/posts?fields=id,message,created_time,permalink_url&access_token=EAATR4ZBcmDZBUBPz8rwAK2SVJYCAlJ5EfBZCZCX6KxIUG99CUndmrATywgogHbF3QHphUZAzb31MhdvwyzDJfjZAepI3s9YpD2IJzIIDW8KQ8yN4ZCvd2bWfrHmpqJM7yzfOVsG6tpldvmsCZA4vZCZBOwZCvj940IwUlB2uGttHZAD6410u5j76CExt9jdGvhLFh6GVDY5ZBrePQmo5ZCQjkp1L0oXnUfZC1m3FsOeysmf3TBQLBXnezQsJxYldqoqLOQx0eCTqcseokWrIQP1SpdrzcGM6sJM6sJM&limit=5',
  method: 'GET'
};

const req = https.request(options, (res) => {
  let body = '';

  res.on('data', (chunk) => {
    body += chunk;
  });

  res.on('end', () => {
    try {
      const response = JSON.parse(body);
      console.log('Facebook API Response:');
      console.log('Status Code:', res.statusCode);
      if (response.error) {
        console.log('Error:', response.error);
      } else if (response.data) {
        console.log('Success! Found', response.data.length, 'posts');
        response.data.forEach((post, index) => {
          console.log(`Post ${index + 1}:`, post.message ? post.message.substring(0, 100) + '...' : 'No message');
        });
      }
    } catch (e) {
      console.log('Parse error:', e.message);
      console.log('Raw response:', body);
    }
  });
});

req.on('error', (e) => {
  console.error('Request error:', e.message);
});

req.end();
