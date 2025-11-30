import http from 'node:http';

const PORT = 5000;

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello from Sidecar!');
});

server.listen(PORT, () => {
    console.log(`Sidecar server listening on port ${PORT}`);
});
