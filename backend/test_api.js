fetch('http://127.0.0.1:3002/api/v1/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ username: 'admin', password: 'admin123' })
})
.then(res => res.json())
.then(data => {
  console.log('Login Response:', data);
  return fetch('http://127.0.0.1:3002/api/v1/auth/me', {
    headers: { 'Authorization': 'Bearer ' + data.access_token }
  });
})
.then(res => res.text())
.then(data => console.log('Profile Response:', data))
.catch(err => console.error('Error:', err));
