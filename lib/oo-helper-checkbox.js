/** @babel */
/** @jsx etch.dom */

import etch from 'etch';

export default class OoCheckbox {
  constructor ({checkboxId, label, description, checked}){
    this.id = checkboxId
    this.label = label
    this.description = description
    this.checked = checked
    etch.createElement(this);
  }

  update (checked) {
    this.checked = checked
    etch.updateElement(this)
  }

  render () {
    // taken from settings
    return (
        <div className="oo-checkbox-grp">
          <div className="checkbox">
            <label>
              <input id={this.id} type='checkbox'
                className="oo-helper-checkbox"
                checked={this.checked}
              />
              <div className="setting-title">{this.label}</div>
            </label>
            <div className="setting-description">{this.description}</div>
          </div>
        </div>
    )
  }
}
