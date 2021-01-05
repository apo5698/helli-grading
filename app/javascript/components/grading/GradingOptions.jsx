import React from 'react';
import CompileOptions from './options/CompileOptions';
import ExecuteOptions from './options/ExecuteOptions';

class GradingOptions extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      rubricItem: props.rubricItem
    };

    this.renderOptionsForRubricItem = this.renderOptionsForRubricItem.bind(this);
  }

  render() {
    return (
      <div className="form-group" style={{maxWidth: '500px'}}>
        {this.renderOptionsForRubricItem()}
      </div>
    )
  }

  renderOptionsForRubricItem() {
    switch(this.state.rubricItem.type) {
      case 'compile':
        return (<CompileOptions />);
      case 'execute':
        return (<ExecuteOptions />);
      default:
      // code block
    }
  }
}

export default GradingOptions;
