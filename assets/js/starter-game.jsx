import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

// Reference: Hangman example done in class

export default function game_init(root, channel) {
  ReactDOM.render(<MemGame channel={channel} />, root);
}

class MemGame extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = {
      displayList: [],
      score: 0,
      delay: -1
    };

    this.channel
        .join()
        .receive("ok", this.onJoin.bind(this))
        .receive("error", resp => { console.log("Unable to join", resp); });
  }

  onJoin(view) {
    console.log("new view", view);
    this.setState(view.game);
  }
  
  onUpdate({game})
  {
  	this.setState(game);
  	
  	if(game.delay == 1)
  	{
  		setTimeout(function()
				{
					var ll = "-1";
  					this.channel.push("guess", {letter: ll})
  						.receive("ok", this.endDelay.bind(this))
					
				}.bind(this), 1000
		);
  	}
  }

  endDelay({game})
  {
  	// state after delay ends
  	this.setState(game);
  }

  render(){
 	return(
 		<div>
				<h1>Memory: Match Tiles (Server)</h1>
			
				<div className = "grid">
					<table>
						<tr>
							<td>{this.getButton(0)}</td>
							<td>{this.getButton(1)}</td>
							<td>{this.getButton(2)}</td>
							<td>{this.getButton(3)}</td>
						</tr>
						<tr>
							<td>{this.getButton(4)}</td>
							<td>{this.getButton(5)}</td>
							<td>{this.getButton(6)}</td>
							<td>{this.getButton(7)}</td>
						</tr>
						<tr>
							<td>{this.getButton(8)}</td>
							<td>{this.getButton(9)}</td>
							<td>{this.getButton(10)}</td>
							<td>{this.getButton(11)}</td>
						</tr>
						<tr>
							<td>{this.getButton(12)}</td>
							<td>{this.getButton(13)}</td>
							<td>{this.getButton(14)}</td>
							<td>{this.getButton(15)}</td>
						</tr>
					</table>
				</div>
				<div className = "score">
					<p>Score: {this.state.score}</p>
				</div>
				<div className = "reset">
					<button type="button" className = "restartbutton" value= "-2" onClick={this.onButtonClick.bind(this)}>Restart</button>
				</div>
			</div>
 	);
  }

  getButton(i)
	{
		return (
			<button type= "button" className = "tiles" value={i} onClick={this.onButtonClick.bind(this)}>{this.state.displayList[i]}</button>
		);
	}
	
  onButtonClick(ev){
  	var ll = ev.target.value;
  	this.channel.push("guess", {letter: ll})
  		.receive("ok", this.onUpdate.bind(this))
  }
}
