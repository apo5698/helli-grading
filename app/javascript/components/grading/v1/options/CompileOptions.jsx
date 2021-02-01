import React from 'react';
import Option from './Option';
import InputOption from './InputOption';

class CompileOptions extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      options: {},
    };

    this.updateOption = this.updateOption.bind(this);
  }

  updateOption(attr, value) {
    const { onOptionsChange } = this.props;
    const { options } = this.state;

    if (value == null) {
      delete options[attr];
    } else {
      options[attr] = value;
    }

    this.setState({
      options: options,
    }, () => {
      console.log(this.state.options);
      onOptionsChange(this.state.options);
    });
  }

  renderLibOptions() {
    return (
      <Option
        optionAttrName="libraries"
        optionText="Libraries"
        optionSmallText="Compile with external libraries"
        updateOption={this.updateOption}
      >
        <div className="mt-2" id="libraries_enabled" style={{ display: 'none' }}>
          <div className="form-group">
            Dependencies: todo
          </div>
        </div>
      </Option>
    );
  }

  renderArgsOptions() {
    const optionSmallText = (
      <>
        Separated by spaces
        <br />
        Use quotes if arguments contain spaces
        <br />
        Use <b>Libraries</b> option above for using JUnit
      </>
    );
    return (
      <Option
        optionAttrName="arguments"
        optionText="Arguments"
        optionSmallText="javac arguments"
        updateOption={this.updateOption}
      >
        <InputOption
          optionAttrName="arguments"
          optionSmallText={optionSmallText}
          optionPlaceHolder="-Xlint:none"
          updateOption={this.updateOption}
        />
      </Option>
    );
  }

  renderCreateOptions() {
    return (
      <Option
        optionAttrName="create"
        optionText="Create files"
        optionSmallText="Program creates output files"
        updateOption={this.updateOption}
      >
        <InputOption
          optionAttrName="create"
          optionSmallText="Separated by spaces"
          optionPlaceHolder="output.txt"
          updateOption={this.updateOption}
        />
      </Option>
    );
  }

  render() {
    return (
      <>
        <h3 className="mb-3">Compile options</h3>
        {this.renderLibOptions()}
        {this.renderArgsOptions()}
        {this.renderCreateOptions()}
      </>
    );
  }
}

export default CompileOptions;
