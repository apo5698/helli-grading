import Papa from 'papaparse';

/**
 * Parse a csv file asynchronously and returns parsed data.
 *
 * @param {File} file csv file
 * @return {Promise} parsed data
 */
export default function asyncParse(file) {
  return new Promise((resolve) => {
    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      complete: (results) => {
        resolve(results.data);
      },
    });
  });
}
