import React from 'react';

class Badge extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      type: props.type,
      pill: props.pill,
      tooltip: props.tooltip
    };

    this.color =
    {
      inactive: 'badge-secondary',
      success: 'badge-success',
      resolved: 'badge-info',
      unresolved: 'badge-danger',
      error: 'badge-primary',
      no_submission: 'badge-warning'
    }
  }

  componentWillReceiveProps(props) {
    this.setState({ type: props.type });
  }

  render() {
    let pill = this.state.pill ? 'badge-pill' : '';
    let tooltip = this.state.tooltip ? `data-toggle='tooltip' title='${this.state.title}'"` : '';
    return (
      <span className={`badge ${pill} ${this.color[this.state.type]}`}>{this.props.children}</span>
    )
  }
}

export default Badge;
