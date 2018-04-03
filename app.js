// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

import shitlist_artifacts from '../../build/contracts/Shitlist.json'

const ipfsAPI = require('ipfs-api');
//const ethUtil = require('ethereumjs-util');
const ipfs = ipfsAPI({host: 'localhost', port: '5001', protocol: 'http'});

let Shitlist = contract(shitlist_artifacts);
var reader;


$(function() {
  $('#claimRefund').click(function() {
    address = document.getElementById('refundAddressUser').value;
    name = document.getElementById('refundClaimName').value;
    Shitlist.deployed().then(function(contractInstance) {
      contractInstance.refundStake.call(name, address, {gas: 500000}).then(function(v){
        $('#claimbeingprocessed').append("<div> Claim Being Processed for: " + address + "</div");
      })
    })
  })
})

$(function(){
  $('#btnCheckName').click(function() {

    name = document.getElementById('searchNameAccused').value;

    Shitlist.deployed().then(
      function(contractInstance) {

      contractInstance.checkClaimExists.call(name).then(
        function(v){
        $('#returnedClaimNumber').append("<div>" + name + " has the following claims against them:</div>");
        for (var i=1; i <= v; i++){
          let claimNumber = i;
          contractInstance.getClaimDetails.call(name, claimNumber).then(function(p){
            //$('#returnedClaimNumber').append(" " + p);
            console.log(p[0]);
            console.log(p[1]);
            buildClaims(p); 
          })
        };
      })
    }
  )
})});

$(function(){
  $('#btnfunctionmakeClaim').click(function() {
    window.claimMade = document.getElementById('claim-description').value;
    window.claimName = document.getElementById('name_accused').value;
    
    saveClaim(claimName, claimMade, reader);
     
      //maybe should have it's own function. 
;})})
  



  function buildClaims(claimobject) {
    let claim = claimobject[0];
    let claim2 = claimobject[1];
   let content = "";
   ipfs.cat(claim).then(function(file) {
    content = file.toString();
    console.log(content);
    $("#claimList1").append("<div>" + content + "</div><div><img src='http://localhost:9001/ipfs/" + claim2 + "' width='475px'/></div>" );
    console.log("</div><div><img src='http://localhost:9001/ipfs/" + claim2 + "/></div>");

    //node.append("<img src='https://ipfs.io/ipfs/" + product[3] + "' width='150px' />");
  
   })
  }

   //reload the page when modals are closed
   $('#modalclose1').click(function() {
    location.reload();
    });

    //reload the page when modals are closed
   $('#modalclose2').click(function() {
    location.reload();
    });

    ///////////////////////////////////////////////////////////////////
    ////////////////////////IPFS IMPLEMENTATION////////////////////////
    ///////////////////////////////////////////////////////////////////
    $("#product-image").change(function(event) {
      
      const file = event.target.files[0]
      reader = new window.FileReader()
      reader.readAsArrayBuffer(file)
    });
 
    function saveImageOnIpfs(reader) {
      return new Promise(function(resolve, reject) {
       const buffer = Buffer.from(reader.result);
       ipfs.add(buffer)
       .then((response) => {
        console.log(response)
        resolve(response[0].hash);
       }).catch((err) => {
        console.error(err)
        reject(err);
       })
      })
     }

     function saveTextBlobOnIpfs(blob) {
      return new Promise(function(resolve, reject) {
       const descBuffer = Buffer.from(blob, 'utf-8');
       ipfs.add(descBuffer)
       .then((response) => {
        console.log(response)
        resolve(response[0].hash);
       }).catch((err) => {
        console.error(err)
        reject(err);
       })
      })
     }

     function saveClaim(name_accused, ipfsText, ipfsImage) {
      let _text;
      let _image;
        saveTextBlobOnIpfs(ipfsText).then(function(id) {
          _text = id;
        saveImageOnIpfs(ipfsImage).then(function(imageid) {
          _image = imageid;
            saveClaimToBlockchain(name_accused, _text, _image);
        })
      })
        
     
    }
    ///////////////////////////////////////////////////////////////////
    ////////////////////////IPFS IMPLEMENTATION////////////////////////
    ///////////////////////////////////////////////////////////////////


    ///////////////////////////////////////////////////////////////////
    ////////////////////////WEBSITE STYLING////////////////////////
    ///////////////////////////////////////////////////////////////////

    $('body').on('hidden.bs.modal', '.modal', function () {
      $(this).removeData('bs.modal');
    });

    ///////////////////////////////////////////////////////////////////
    ////////////////////////WEBSITE STYLING////////////////////////
    ///////////////////////////////////////////////////////////////////


function saveClaimToBlockchain(claimName, ipfsText, ipfsOfImage){

  Shitlist.deployed().then(
    function(contractInstance) {console.log(contractInstance.makeClaim(claimName, ipfsText, ipfsOfImage, {value: web3.toWei(1, 'ether'), gas: 4400000, from: web3.eth.accounts[0]}).then(function(v) {console.log()}))})
}
   

$( document ).ready(function() {
 if (typeof web3 !== 'undefined') {
  console.warn("Using web3 detected from external source like Metamask")
  // Use Mist/MetaMask's provider
  window.web3 = new Web3(web3.currentProvider);
 } else {
  console.warn("No web3 detected. Falling back to http://localhost:7545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
  // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
  window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
 }

 Shitlist.setProvider(web3.currentProvider);


});

