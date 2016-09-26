import React from 'react';
import { connect } from 'react-redux';

const Counter = React.createClass({
	render() {
		const { value, onIncrement, onDecrement } = this.props;
		return (
			<div>
				<p>
					Value: { value }
				</p>
				<p>
					<button onClick={onIncrement}>+</button>
					<button onClick={onDecrement}>-</button>
				</p>
			</div>
		);
	}
});

export default connect(
	state => { return { value: state.value }; },
	dispatch => { 
		return {
			onIncrement: () => dispatch({ type: 'INCREMENT' }),
			onDecrement: () => dispatch({ type: 'DECREMENT' })
		}; 
	}
)(Counter);
