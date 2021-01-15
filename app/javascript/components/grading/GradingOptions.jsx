import React from 'react';
import CompileOptions from './options/CompileOptions';
import ExecuteOptions from './options/ExecuteOptions';

class GradingOptions extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      rubricItem: props.rubricItem,
    };
  }

  renderOptionsForRubricItem() {
    const { onOptionsChange } = this.props;
    const { rubricItem: { type } } = this.state;
    switch (type) {
      case 'compile':
        return (
          <CompileOptions
            onOptionsChange={onOptionsChange}
          />
        );
      case 'execute':
        return (
          <ExecuteOptions
            onOptionsChange={onOptionsChange}
          />
        );
      default:
        return (<></>);
    }
  }

  render() {
    return (
      <div className="form-group" style={{ maxWidth: '500px' }}>
        {this.renderOptionsForRubricItem()}
      </div>
    );
  }
}

export default GradingOptions;
