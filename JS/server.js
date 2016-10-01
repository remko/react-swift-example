import React from 'react';
import { renderToString } from 'react-dom/server';
import { createStore } from 'redux';
import { Provider } from 'react-redux';
import Counter from './Counter';
import { rootReducer } from './reducers';

export function render(preloadedState = undefined) {
	const store = createStore(rootReducer, preloadedState);
	return {
		html: renderToString(
			<Provider store={store}>
				<Counter/>
			</Provider>
		),
		state: JSON.stringify(store.getState())
	};
}
