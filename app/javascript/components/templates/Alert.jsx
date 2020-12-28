import React from 'react';

class Alert extends React.Component {
  constructor(props) {
    super(props);

    this.type =
      {
        warning: 'alert-warning',
        danger: 'alert-danger',
        success: 'alert-success',
        info: 'alert-info',
        error: 'alert-primary'
      }
  }

  render() {
    return (
      <div className={`alert alert-dismissible ${this.type[this.props.type]}`}>
        <button type="button" className="close" data-dismiss="alert">&times;</button>
        <span className="new-line">{this.props.message}</span>
      </div>
    );
  }
}

export default Alert;
