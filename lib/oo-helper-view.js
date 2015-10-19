/** @babel */
/** @jsx etch.dom */

import etch from 'etch';
import OoCheckbox from './oo-helper-checkbox'

function getMethods(obj) {
  var result = [];
  for (var id in obj) {
    try {
      if (typeof(obj[id]) == "function") {
        result.push(id );//+ ": " + obj[id].toString());
      }
    } catch (err) {
      result.push(id + ": inaccessible");
    }
  }
  return result;
}

export default class OoHelperView {
  // The constructor assigns initial state, then associates the component with
  // an element via `etch.createElement`
  constructor (state) {
    // calling etch.createElement invokes render, so all initialization
    // of local variables must be done beforehand.
    this.state = state;
    etch.createElement(this);
  }

  serialize () {

  }
  destroy () {
    this.remove();
  }

  getElement () {
    console.log("get element state")
    console.log(this.state)
    return this.render.call(this);
  }
  // When your component's element is created or updated, its content will be
  // based on the result of the `render` method.
  render () {

    return (
      <div className='oo-helper-container'>
        <h2>C++ Class Generator</h2>
        <label>Class Name</label>
        <atom-text-editor className="oo-helper-input" ref="ooHelperClassnameInput" attributes={{mini: true}}></atom-text-editor>

        <OoCheckbox checkboxId="oohelper-useParentClass" label="Parent Class"
          description="Check on to provide the name of a parent class."
          checked={this.state.parentClassChecked} />
        <atom-text-editor className="oo-helper-input" ref="ooHelperParentClassnameInput" attributes={{mini: true}}
        ></atom-text-editor>

        <OoCheckbox checkboxId="oohelper-virtualDestructor" label="Virtual Destructor" description='Check on to make the destructor virtual.'
        checked={this.state.virtualDestructorChecked} />
        <div>

        <OoCheckbox checkboxId="oohelper-addCopyConstructor" label="Copy Constructor" description='Check on to add copy constructor boilerplate.'
        checked={this.state.copyConstructorChecked} />

        </div>

        <OoCheckbox checkboxId="oohelper-addAssignmentOperator" label="Assignment Operator" description="Check on to add assignment operator boilerplate."
        checked={this.state.assignmentOperatorChecked} />
        <button className="oo-helper-button btn" ref='pressButton'>Create</button>
      </div>
    )
  }

  getClassname() {
    return this.refs.ooHelperClassnameInput.getModel().getText();
  }
  getParentClassname() {
    return this.refs.ooHelperParentClassnameInput.getModel().getText();
  }
}
