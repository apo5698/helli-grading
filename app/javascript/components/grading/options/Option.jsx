import React from 'react';

class Option extends React.Component {
  constructor(props) {
    super(props);

    this.toggleOptions = this.toggleOptions.bind(this);
  }

  toggleOptions(event) {
    let checkbox = event.target;
    let id = checkbox.id;
    let options = $(`div#${id}`);
    if (checkbox.checked) {
      options.show();
    } else {
      options.hide();
    }
  }

  render() {
    return (
      <div className="form-group">
        <div className="custom-control custom-checkbox">
          <input name={`${this.props.optionNamePrefix}[enabled]`} type="hidden" value="0" />
          <input className="custom-control-input" type="checkbox" value="1" onChange={this.toggleOptions}
                 name={`${this.props.optionNamePrefix}[enabled]`} id={`${this.props.optionIdPrefix}_enabled`} />
          <label className="custom-control-label" htmlFor={`${this.props.optionIdPrefix}_enabled`}>{this.props.optionText}</label>
          <small className="form-text text-muted mt-0">{this.props.optionSmallText}</small>
          {/*hidden*/}
          {this.props.children}
        </div>
      </div>
    )
  }
}

export default Option;
