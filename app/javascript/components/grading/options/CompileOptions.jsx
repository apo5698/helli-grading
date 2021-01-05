import React from 'react';
import Option from './Option';
import InputOption from './InputOption';

class CompileOptions extends React.Component {
  constructor(props) {
    super(props);

    this.renderLibOptions = this.renderLibOptions.bind(this);
    this.renderArgsOptions = this.renderArgsOptions.bind(this);
    this.renderCreateOptions = this.renderCreateOptions.bind(this);
  }

  render() {
    return (
      <>
        <h3 className='mb-3'>Compile options</h3>
        {this.renderLibOptions()}
        {this.renderArgsOptions()}
        {this.renderCreateOptions()}
      </>
    )
  }

  renderLibOptions() {
    let optionNamePrefix = '[options][lib]';
    let optionIdPrefix = '_options_lib';
    return (
      <Option optionNamePrefix={optionNamePrefix} optionIdPrefix={optionIdPrefix}
              optionText='Libraries'
              optionSmallText='Compile with external libraries'>
        <div className='mt-2' id={`${optionIdPrefix}_enabled`} style={{display: 'none'}}>
          <div className='form-group'>
            Dependencies: todo
          </div>
        </div>
      </Option>
    );
  }

  renderArgsOptions() {
    let optionNamePrefix = '[options][args]';
    let optionIdPrefix = '_options_args';
    let optionSmallText = (
      <>
        Separated by spaces<br/>
        Use quotes if arguments contain spaces<br/>
        Use <b>Libraries</b> option above for using JUnit
      </>
    )
    return (
      <Option optionNamePrefix={optionNamePrefix} optionIdPrefix={optionIdPrefix}
              optionText='Arguments'
              optionSmallText='javac arguments'>
        <InputOption optionNamePrefix={optionNamePrefix} optionIdPrefix={optionIdPrefix}
                     optionPostfix='javac'
                     optionSmallText={optionSmallText}
                     optionPlaceHolder='-Xlint:none' />
      </Option>
    );
  }

  renderCreateOptions() {
    let optionNamePrefix = '[options][create]';
    let optionIdPrefix = '_options_create';
    return (
      <Option optionNamePrefix={optionNamePrefix} optionIdPrefix={optionIdPrefix}
              optionText='Create files'
              optionSmallText='Program creates output files'>
        <InputOption optionNamePrefix={optionNamePrefix} optionIdPrefix={optionIdPrefix}
                     optionPostfix='filename'
                     optionSmallText='Separated by spaces'
                     optionPlaceHolder='output.txt' />
      </Option>
    );
  }
}

export default CompileOptions;
