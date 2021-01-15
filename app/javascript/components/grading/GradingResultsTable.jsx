import React from 'react';
import GradingResultsRow from './GradingResultsRow';

class GradingResultsTable extends React.Component {
  constructor(props) {
    super(props);

    this.children = [];

    this.renderGradingResultsRows = this.renderGradingResultsRows.bind(this);
    this.runAll = this.runAll.bind(this);
  }

  runAll(options) {
    this.children.forEach((child) => child.current.run(options));

    event.preventDefault();
  }

  renderGradingResultsRows() {
    const { rubricItem, gradeItems, incrementCount } = this.props;

    const html = [];
    gradeItems.forEach((gradeItem) => {
      const ref = React.createRef();
      this.children.push(ref);
      html.push(<GradingResultsRow
        ref={ref}
        key={`autograding-item-${gradeItem.id}`}
        rubricItem={rubricItem}
        gradeItem={gradeItem}
        incrementCount={incrementCount}
      />);
    });
    return html;
  }

  render() {
    return (
      <div className="table-responsive">
        <table className="table table-hover table-striped">
          <thead>
            <tr className="table-active">
              <th scope="col" style={{ maxWidth: '100px' }}>Student</th>
              <th scope="col">File</th>
              <th scope="col">Status</th>
              <th scope="col">Grade</th>
              <th scope="col">Output</th>
              <th scope="col" style={{ maxWidth: '250px' }}>Feedback</th>
              <th scope="col">Action</th>
            </tr>
          </thead>
          <tbody>
            {this.renderGradingResultsRows()}
          </tbody>
        </table>
      </div>
    );
  }
}

export default GradingResultsTable;
