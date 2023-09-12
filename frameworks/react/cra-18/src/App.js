import logo from './logo.svg';
import './App.css';
import { useState, useEffect } from 'react';

function App() {
  const [item, setItems] = useState()

  useEffect(() => {
    fetch(`https://api.github.com/repos/appsignal/appsignal-javascript`)
      .then((res) => res.json())
      .then((data) => {
        console.log({ data })
        setItems(data)
      })
  }, []);


  // throw new Error("This is an error")
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <Undefined />
        <Item item={item} />
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

function Item({props}) {
  return (
    <div>
      <p>
        { prop.item.owner.login }
      </p>
    </div>
  )
}

export default App;
