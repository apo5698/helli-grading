import React from 'react';

class Option extends React.Component {
  constructor(props) {
    super(props);

    this.onOptionChange = this.onOptionChange.bind(this);
  }

  onOptionChange(event) {
    const {
      optionAttrName,
      updateOption,
    } = this.props;
    const checkbox = event.target;
    const { id } = checkbox;
    const options = $(`div#${id}`);

    let value = null;
    if (checkbox.checked) {
      options.show();
      value = options.find('input')
        .val();
    } else {
      options.hide();

    }
    updateOption(optionAttrName, value);
  }

  render() {
    const {
      children,
      optionText,
      optionSmallText,
      optionAttrName,
    } = this.props;

    return (
      <div className="form-group">
        <div className="custom-control custom-checkbox">
          <input
            className="custom-control-input"
            type="checkbox"
            value="0"
            onChange={this.onOptionChange}
            id={`${optionAttrName}_enabled`}
          />
          <label className="custom-control-label"
                 htmlFor={`${optionAttrName}_enabled`}>{optionText}</label>
          <small className="form-text text-muted mt-0">{optionSmallText}</small>
          {children}
        </div>
      </div>
    );
  }
}

export default Option;
