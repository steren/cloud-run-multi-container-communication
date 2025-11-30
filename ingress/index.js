import http from 'node:http';

const PORT = process.env.PORT || 8080;
const SIDECAR_PORT = 5000; // Port where the sidecar is listening

const server = http.createServer(async (req, res) => {
  try {
    const response = await fetch(`http://localhost:${SIDECAR_PORT}`);
    const data = await response.text();

    const response2 = await fetch(`http://sidecar:${SIDECAR_PORT}`);
    const data2 = await response2.text();

    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`I sent a request to http://localhost:${SIDECAR_PORT} and received: ${data}\nI sent a request to http://sidecar:${SIDECAR_PORT} and received: ${data2}`);
  } catch (error) {
    console.error(error);
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end(`Error communicating with sidecar: ${error.message}`);
  }
});

server.listen(PORT, () => {
  console.log(`Ingress server listening on port ${PORT}`);
});
