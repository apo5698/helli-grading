import * as React from 'react';
import { useEffect, useState } from 'react';
import { Descriptions } from 'antd';
import { helliApiUrl } from '../../../HelliApiUtil';

interface Dependency {
  version: string,
}

const Checkstyle = () => {
  const [checkstyle, setCheckstyle] = useState<Dependency>({
    version: '',
  });

  useEffect(() => {
    fetch(helliApiUrl('dependencies/cs-checkstyle'))
      .then((response) => response.json())
      .then((data) => {
        setCheckstyle(data);
      });
  }, []);

  return (
    <Descriptions title="Checkstyle Info">
      <Descriptions.Item label="Version">{checkstyle.version}</Descriptions.Item>
    </Descriptions>
  );
};

export default Checkstyle;
