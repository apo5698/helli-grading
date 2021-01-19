import * as React from 'react';

type Props = {
  children: any,
  tooltip?: undefined,
  type: string,
}

function Badge(props: Props) {
  const {
    children,
    tooltip,
    type,
  } = props;

  return (
    <span
      className={`badge badge-${type}`}
      {...(tooltip ? {
        dataToggle: 'tooltip',
        tooltip,
      } : {})}
    >
      {children}
    </span>
  );
}

export default Badge;
