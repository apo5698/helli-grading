import React from 'react';

class InputOption extends React.Component {
  constructor(props) {
    super(props);

    this.onOptionChange = this.onOptionChange.bind(this);
  }

  onOptionChange(event) {
    const {
      optionAttrName,
      updateOption,
    } = this.props;

    let value = event.target.value;
    updateOption(optionAttrName, value);
  }

  render() {
    const {
      optionAttrName,
      optionSmallText,
      optionPlaceHolder,
    } = this.props;

    return (
      <div className='mt-2' id={`${optionAttrName}_enabled`} style={{ display: 'none' }}>
        <div className='form-group'>
          <input
            className="form-control code"
            placeholder={optionPlaceHolder}
            type="text"
            onChange={this.onOptionChange}
          />
          <small className="form-text text-muted">
            {optionSmallText}
          </small>
        </div>
      </div>
    );
  }
}

export default InputOption;
