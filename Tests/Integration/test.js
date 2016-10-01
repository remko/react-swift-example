const webdriverio = require('webdriverio');
import { expect } from 'chai';

const options = { 
	desiredCapabilities: { 
		browserName: 'phantomjs'
	}, 
  // logLevel: 'verbose',
	baseUrl: 'http://localhost:8080',
	port: 4444 
}; 

describe("Integration", () => {
	let client;

	beforeEach(() => {
		client = webdriverio 
			.remote(options) 
			.init();
	});

	it("should work with bare server", () => {
		return client
			.url('http://localhost:8080/') 
			.getTitle().then(title => { 
				expect(title).to.equal("React+Swift Test App");
			}) 
			.getText("#root p:first-of-type").then(text => {
				expect(text).to.equal("Value: 42");
			})
			.click("button")
			.click("button")
			.getText("#root p:first-of-type").then(text => {
				expect(text).to.equal("Value: 44");
			})
			.click("button + button")
			.getText("#root p:first-of-type").then(text => {
				expect(text).to.equal("Value: 43");
			});
	});

	it("should work with dev server", () => {
		return client
			.url('http://localhost:8081/') 
			.getTitle().then(title => { 
				expect(title).to.equal("React+Swift Test App");
			}) 
			.waitForExist("#root p:first-of-type", 5000)
			.getText("#root p:first-of-type").then(text => {
				expect(text).to.equal("Value: 42");
			})
			.click("button")
			.click("button")
			.getText("#root p:first-of-type").then(text => {
				expect(text).to.equal("Value: 44");
			})
			.click("button + button")
			.getText("#root p:first-of-type").then(text => {
				expect(text).to.equal("Value: 43");
			});
	});
});
