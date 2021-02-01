import React from 'react';
import GradingOptions from './GradingOptions';
import GradingResultsTable from './GradingResultsTable';
import Alert from '../../templates/Alert';

class GradingPagePerRubricItem extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      submitting: false,
      finishedCount: 0,
      totalCount: -1,

      options: {},
    };

    this.table = React.createRef();

    this.handleSubmit = this.handleSubmit.bind(this);
    this.onOptionsChange = this.onOptionsChange.bind(this);
    this.incrementCount = this.incrementCount.bind(this);
  }

  componentDidMount() {
    const { rubricItem: { id } } = this.props;

    $(`#autograding-${id}`)
      .tab('show');
  }

  handleSubmit(event) {
    const { options } = this.state;

    this.setState({
      submitting: true,
      totalCount: this.table.current.children.length,
    });
    this.table.current.runAll(options);
    event.preventDefault();
  }

  onOptionsChange(options) {
    this.setState({
      options,
    }, () => {
      console.log(this.state.options);
    });
  }

  incrementCount() {
    const { rubricItem: { name } } = this.props;
    const {
      finishedCount,
      totalCount,
    } = this.state;

    $('#flash')
      .html(<Alert type="success" message={`Run ${name} complete.`} />);
    this.setState({
      finishedCount: finishedCount + 1,
    });
    if (this.state.finishedCount === totalCount) {
      window.location.reload();
    }
  }

  renderCount() {
    const {
      submitting,
      finishedCount,
      totalCount,
    } = this.state;

    if (submitting) {
      return (
        <>
          <span> </span>
          {finishedCount}
          /
          {totalCount}
        </>
      );
    }
    return '';
  }

  renderRunButton() {
    return (
      <div className="form-group d-flex align-items-center">
        <input
          className="btn btn-primary"
          type="submit"
          name="commit"
          value="Run"
        />
        <div className="d-inline ml-2">
          <span id="grading-status" />
        </div>
        {this.renderCount()}
      </div>
    );
  }

  render() {
    const {
      rubricItem,
      rubricItem: { path },
      gradeItems,
    } = this.props;

    return (
      <div className="tab-pane show active" id={`autograding-${rubricItem}`}>
        <form onSubmit={this.handleSubmit}>
          <GradingOptions
            rubricItem={rubricItem}
            onOptionsChange={this.onOptionsChange}
          />
          {this.renderRunButton()}
        </form>

        <h3>Results</h3>
        <div id="autograding-result">
          <GradingResultsTable
            ref={this.table}
            rubricItem={rubricItem}
            gradeItems={gradeItems}
            incrementCount={this.incrementCount}
          />
        </div>
        <div className="float-right mt-2 mb-4">
          <a
            href={path}
            data-method="delete"
            data-confirm="All grading results will be cleared. Proceed?"
          >
            Reset grading status
          </a>
        </div>
      </div>
    );
  }
}

export default GradingPagePerRubricItem;
