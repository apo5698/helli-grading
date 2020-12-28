import React from 'react';

class InputOption extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className='mt-2' id={`${this.props.optionIdPrefix}_enabled`} style={{display: 'none'}}>
        <div className='form-group'>
          <input className="form-control code" placeholder={this.props.optionPlaceHolder} type="text" name={`${this.props.optionNamePrefix}[${this.props.optionPostfix}]`}
                 id={`${this.props.optionIdPrefix}_${this.props.optionPostfix}`} />
          <small className="form-text text-muted">
            {this.props.optionSmallText}
          </small>
        </div>
      </div>
    )
  }
}

export default InputOption;
