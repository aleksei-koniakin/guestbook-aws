import React from 'react';
import {shallow, mount} from 'enzyme';

import Message from './Message';

describe('Message', () => {
  const shallowMessage = props => shallow(<Message {...props}/>);
  const mountMessage = props => mount(<Message {...props}/>);

  it('should create component', () => {
    mountMessage().should.have.type(Message);
  });

  it('should wrap children with div', () => {
    shallowMessage().should.have.tagName('div');
  });

  it('should use passed className', () => {
    shallowMessage({
      className: 'test-class'
    }).should.have.className('test-class');
  });

  // TODO Add more tests
});
