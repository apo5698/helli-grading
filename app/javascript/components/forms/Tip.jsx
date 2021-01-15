/* eslint-disable react/destructuring-assignment */

import React from 'react';
import PropTypes from 'prop-types';

const Tip = (props) => (
  <small className="form-text text-muted" id={`${props.id}-tip`}>
    {props.message}
  </small>
);

Tip.propTypes = {
  message: PropTypes.string.isRequired,
  id: PropTypes.string,
};

Tip.defaultProps = {
  id: '',
};

export default Tip;
