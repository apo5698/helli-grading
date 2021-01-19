import * as React from 'react';
import Badge from '../Badge';

type Props = {
  type: string,
  children: any,
}

class Status extends React.Component<Props> {
  static color = {
    inactive: 'secondary',
    success: 'success',
    resolved: 'primary',
    unresolved: 'warning',
    error: 'danger',
    no_submission: 'info',
  };

  render() {
    const {
      type,
      children,
    } = this.props;
    return <Badge type={Status.color[type]}>{children}</Badge>;
  }
}

export default Status;
