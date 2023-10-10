import React from 'react';
import logo from './logo.svg';
import { useState, useEffect } from 'react';
import './App.css';
import { useGetPokemonByNameQuery } from './services/pokemon'

function App() {
  const { data: { abilities }, error, isLoading } = useGetPokemonByNameQuery('bulbasaur')
  console.log({ abilities })
  const items = [
    { key: "overgrown" },
    { key: "chlorophyll" }
  ];
  const mappedItems = items.map((item) => ({
    hasAbility: abilities?.find((a: any) => a.ability.name === item.key)
  }));

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
        {mappedItems.join("")}
      </header>
    </div>
  );
}

export default App;
