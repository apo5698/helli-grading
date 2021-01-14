import React from 'react';
import PropTypes from 'prop-types';
import asyncParse from './AsyncPapa';

class MoodleUpload extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      file: null,
      placeholder: 'Choose file',
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
      this.setState({ placeholder: file.name });
    });
  }

  upload(data) {
    const { url } = this.props;

    fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ participant: data }),
    }).then((response) => {
      this.enableButton();

      if (!response.ok) {
        throw Error(response.statusText);
      }
      return response;
    }).then(() => {
      window.location.reload();
    }).catch((error) => {
      console.error(error);
    });
  }

  render() {
    const { placeholder, uploadButtonText, uploadButtonDisabled } = this.state;

    return (
      <div className="form-group">
        <div className="input-group">
          <div className="custom-file">
            <input
              className="custom-file-input"
              type="file"
              id="moodle-csv"
              accept=".csv"
              required
              onChange={this.select}
            />
            <label className="custom-file-label" htmlFor="moodle-csv">{placeholder}</label>
          </div>
          <div className="input-group-append">
            <input
              className="input-group-text"
              type="submit"
              value={uploadButtonText}
              disabled={uploadButtonDisabled}
              onClick={async () => {
                this.disableButton();
                this.upload(await asyncParse(this.state.file));
              }}
            />
          </div>
        </div>
        <small className="form-text text-muted" id="moodle-grade-worksheet">
          It should look like &quot;Grades-CSC 116 (004) FALL 2020-Day 11-293581.csv&quot;
        </small>
      </div>
    );
  }
}

MoodleUpload.propTypes = {
  url: PropTypes.string.isRequired,
};

export default MoodleUpload;
