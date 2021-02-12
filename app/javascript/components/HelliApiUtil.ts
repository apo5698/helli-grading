export const helliApiUrl = (url = '') => `${window.location.protocol}//api.${window.location.host}/${url}`;

const fetchHelliApi = async (url, method, body = {}) => {
  if (method === 'GET') {
    return (await fetch(helliApiUrl(url))).json();
  }

  return (await fetch(helliApiUrl(url), {
    method,
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  })).json();
};

export const getHelliApi = async (url = '') => fetchHelliApi(url, 'GET');
export const postHelliApi = async (url = '', body = {}) => fetchHelliApi(url, 'POST', body);
export const putHelliApi = async (url = '', body = {}) => fetchHelliApi(url, 'PUT', body);
export const deleteHelliApi = async (url = '', body = {}) => fetchHelliApi(url, 'DELETE', body);

// Returns all public dependencies.
export const getDependencies = async () => fetchHelliApi('dependencies', 'GET');
