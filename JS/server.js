import Counter from './Counter';
import { rootReducer } from './reducers';
import { default as genericRender } from './render';

export const render = genericRender.bind(null, rootReducer, Counter);
