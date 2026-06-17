export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Cek apakah request ditujukan ke subdomain API, Mobile, atau Frontend
    if (url.hostname === 'api.arjunapijak.web.id') {
      // Arahkan ke Cloud Run Backend
      url.hostname = 'arjuna-backend-60410062142.asia-southeast2.run.app';
    } else if (url.hostname === 'mobile.arjunapijak.web.id') {
      // Arahkan ke Cloud Run Mobile
      url.hostname = 'arjuna-mobile-60410062142.asia-southeast2.run.app';
    } else {
      // Arahkan ke Cloud Run Frontend
      url.hostname = 'arjuna-frontend-60410062142.asia-southeast2.run.app';
    }
    
    // Buat request baru dengan URL yang sudah diubah
    const modifiedRequest = new Request(url.toString(), {
      method: request.method,
      headers: request.headers,
      body: request.body,
      redirect: "follow"
    });
    
    // Jalankan request ke Cloud Run dan kembalikan responnya
    return fetch(modifiedRequest);
  }
}
