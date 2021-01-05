import React from 'react';
import serialize from 'form-serialize';
import GradingOptions from './GradingOptions';
import GradingResultsTable from './GradingResultsTable';
import Alert from '../templates/Alert';

class GradingPagePerRubricItem extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      submitting: false,
      finishedCount: 0,
      totalCount: -1
    };

    this.table = React.createRef();

    this.handleSubmit = this.handleSubmit.bind(this);
    this.renderRunButton = this.renderRunButton.bind(this);
    this.renderCount = this.renderCount.bind(this);
    this.incrementCount = this.incrementCount.bind(this);
  }

  handleSubmit(event) {
    this.setState({
      submitting: true,
      totalCount: this.table.current.children.length
    });
    let options = JSON.stringify(serialize(event.target, { hash: true }));
    let r = this.table.current.runAll(options);

    event.preventDefault();
  }

  incrementCount() {
    $('#flash').html(<Alert type='success' message={`Run ${this.props.rubricItem.name} complete.`} />);

    console.log(this.state.finishedCount);
    this.setState({
      finishedCount: this.state.finishedCount + 1
    });
    if (this.state.finishedCount === this.state.totalCount) {
      window.location.reload();
    }
  }

  componentDidMount() {
    $(`#autograding-${this.props.rubricItem.id}`).tab('show');
  }

  render() {
    return (
      <div className='tab-pane show active' id={`autograding-${this.props.rubricItem}`}>
        <form onSubmit={this.handleSubmit}>
          <GradingOptions rubricItem={this.props.rubricItem}/>
          {this.renderRunButton()}
        </form>

        <h3>Results</h3>
        <div id='autograding-result'>
          <GradingResultsTable ref={this.table} rubricItem={this.props.rubricItem} gradeItems={this.props.gradeItems}
                               incrementCount={this.incrementCount}/>
        </div>
        <div className='float-right mt-2 mb-4'>
          <a href={this.props.rubricItem.path} data-method='delete' data-confirm='All grading results will be cleared. Proceed?'>Reset grading status</a>
        </div>
      </div>
    )
  }

  renderRunButton() {
    return (
      <div className='form-group d-flex align-items-center'>
        <input type="submit" name="commit" value="Run" className="btn btn-primary" data-disable-with="Running..." />
        <div className='d-inline ml-2'>
          <span id='grading-status' />
        </div>
        {this.renderCount()}
      </div>
    )
  }

  renderCount() {
    if (this.state.submitting) {
      return (
        <>
          <span> </span>
          {this.state.finishedCount}/{this.state.totalCount}
        </>
      );
    }
    return '';
  }
}

export default GradingPagePerRubricItem;
