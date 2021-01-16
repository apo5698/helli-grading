import React from 'react';
import PropTypes from 'prop-types';

import asyncParse from './AsyncPapa';
import Tip from './Tip';

class CSV extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      file: null,
      label: 'Choose file',
      uploadButtonText: 'Upload',
      uploadButtonDisabled: false,
    };

    this.enableButton = this.enableButton.bind(this);
    this.disableButton = this.disableButton.bind(this);

    this.select = this.select.bind(this);
    this.upload = this.upload.bind(this);
  }

  enableButton() {
    this.setState({ uploadButtonText: 'Upload', uploadButtonDisabled: false });
  }

  disableButton() {
    this.setState({ uploadButtonText: 'Uploading...', uploadButtonDisabled: true });
  }

  select(event) {
    this.setState({ file: event.target.files[0] }, () => {
      const { file } = this.state;
      this.setState({ label: file.name });
    });
  }

  upload(data) {
    const { url } = this.props;

    fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ participant: data }),
    }).then(() => {
      this.enableButton();
      window.location.reload();
    });
  }

  render() {
    const { id, tip } = this.props;

    const {
      file, label, uploadButtonText, uploadButtonDisabled,
    } = this.state;

    return (
      <div className="form-group">
        <div className="input-group">
          <div className="custom-file">
            <input
              className="custom-file-input"
              type="file"
              id={id}
              accept=".csv"
              required
              onChange={this.select}
            />
            <label className="custom-file-label" htmlFor={id}>{label}</label>
          </div>
          <div className="input-group-append">
            <input
              className="input-group-text"
              type="submit"
              value={uploadButtonText}
              disabled={uploadButtonDisabled}
              onClick={async () => {
                this.disableButton();
                this.upload(await asyncParse(file));
              }}
            />
          </div>
        </div>
        <Tip message={tip} id={id} />
      </div>
    );
  }
}

CSV.propTypes = {
  id: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  tip: PropTypes.string,
};

CSV.defaultProps = {
  tip: '',
};

export default CSV;
