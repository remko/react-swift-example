import React from 'react';
import { renderToString } from 'react-dom/server';
import { createStore } from 'redux';
import { Provider } from 'react-redux';

function render(reducer, Component, preloadedState = undefined) {
	const store = createStore(reducer, preloadedState);
	return {
		html: renderToString(
			<Provider store={store}>
				<Component/>
			</Provider>
		),
		state: JSON.stringify(store.getState())
	};
}

export default render;
