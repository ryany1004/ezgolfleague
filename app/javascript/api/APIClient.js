import applyConverters from 'axios-case-converter';
import axios from 'axios';

export default {
  client() {
    const client = applyConverters(axios.create());
    client.defaults.headers.post['Content-Type'] = 'application/json';

    return client;
  },
  formHeader(token) {
    return {
      headers: {
        'X-CSRF-TOKEN': token,
      },
    };
  },
  runAll(requests) {
    return Promise.all(requests);
  },
};
