import * as React from 'react';
import { Form } from 'react-bootstrap';

import Compile from './options/Compile';

type Props = {
  type: string,
  setOptions: Function,
}

const optionComponents = {
  Compile,
};

const Options = (props: Props) => {
  const {
    type,
    setOptions,
  } = props;
  const OptionComponent = optionComponents[type];

  return (
    <Form>
      <legend>{`${type} Options`}</legend>
      <OptionComponent setOptions={setOptions} />
    </Form>
  );
};

export default Options;
