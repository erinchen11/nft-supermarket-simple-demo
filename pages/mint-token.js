import {ethers} from 'ethers'
import {useState} from 'react'
import Web3Modal from 'web3modal'
import {create as ipfsHttpClient} from 'ipfs-http-client'
import { nftaddress, nftmarketaddress } from '../config'
import NFT from '../artifacts/contracts/NFT.sol/NFT.json'
import {useRouter} from 'next/router'
import Market from '../artifacts/contracts/Market.sol/Market.json'

// when user mint an file, use ipfs to store data of NFT, and use infura ipfs service
// connect to infura service
const client = ipfsHttpClient('https://ipfs.infura.io:5001/api/v0')

export default function MintItem() {
    // what have to store and update state?
    // FileURL for ipfs, upload image: name, price, description
    // use useState to setup file url
    const [fileUrl, setFileUrl] = useState(null)
    const [formInput, updateFormInput] = useState({price: '', name:'',
description:''})
    // use useRouter() to change web page
    const router = useRouter()

    // function - when user upload image to mint  NFT and add the image to ipfs
    // use form to let user upload their image.
    // onChange is React's event to handle form
    async function onChange(e) {
        // get the file from form
        const file = e.target.files[0]
        // have to store user's uploaded image to IPFS, and get the CID of it
        // the url of file is "the connect address"/CID
        // use try-catch make sure user has uploaded
        try {
        // from doc of ipfs-http-client, client has to use 'add' to upload file (CID)
        // use progress object to set anoymous function to track upload file
        const added = await client.add(
            file, {
                progress: (prog) => console.log(`received: ${prog}`)
            })
        // after get the CID of uploaded file, set up the url
        const url = `https://ipfs.infura.io/ipfs/${added.path}`
        // update the state of file url, that on IPFS
        setFileUrl(url)
        // test IPFS url
        console.log("IPFS url : ",url);
        } catch (error) {
            console.log('Error uploading file:', error)
        }
    }

    // after get the url of upload file on ipfs, 
    // for Marketplace, have to upload the infomation of file to ipfs - metadata 
    // the information in in JSON format
    // want to store the infomation of file are :
    // name, description, fileURL

    async function createMarket() {
        const {name, description, price} = formInput 
        if(!name || !description || !price || !fileUrl) return 
        // before upload file to IPFS, must stringfy the information of file
        const data = JSON.stringify({
            name, description, image: fileUrl
        })
        // after the image uploaded, want to pass the url and save it on blockchain network
        try {
            const added = await client.add(data)
            const url = `https://ipfs.infura.io/ipfs/${added.path}`
            // run a function that creates sale and passes in the url  
            createSale(url)
            } catch (error) {
                console.log('Error uploading file:', error)
            }
    }
    // sell the file which already uploaded IPFS on marketplace
    // must pass url as argument of function
    // connect to wallet
    // use the mintToken function of NFT contract to mint the file into NFT
    // pay the listing fee
    // use the createMarketItem of Marketplace contract to list the NFT
    async function createSale(url) {
        // connect to the wallet, get the signer of the wallet
        const web3Modal = new Web3Modal()
        const connection = await web3Modal.connect()
        const provider = new ethers.providers.Web3Provider(connection)
        const signer = provider.getSigner()

        // use mintToken function to create NFT token of file
        // create a instance of NFT contract
        let contract = new ethers.Contract(nftaddress, NFT.abi, signer)
        let transaction = await contract.mintToken(url)
        let tx = await transaction.wait()
        // get transaction's event, and get the value which will display on web site
        // get tokenId of NFT that be pass to creatMarketItem()
            console.log("transaction is ", tx)
        let event = tx.events[0]
            console.log("event is :", event)
        let value = event.args[2]
        let tokenId = value.toNumber()
            console.log("value is ", value)
            console.log("tokenId is ", tokenId)
        const price = ethers.utils.parseUnits(formInput.price, 'ether')
        
        // list the NFT on marketplace
        // call the createMarketItem of Marketplace contract 
        contract = new ethers.Contract(nftmarketaddress, Market.abi, signer)
        // get the listing fee from contract and convert it into string
        let listingPrice = await contract.getListingPrice()
        listingPrice = listingPrice.toString()
        // pay the listing fee
        transaction = await contract.makeMarketItem(nftaddress, tokenId, price, {value: listingPrice})
        await transaction.wait()
        // push it to the home router
        router.push('./')
    }

    return (
        <div className='flex justify-center'>
            <div className='w-1/2 flex flex-col pb-12'>
                <input
                placeholder='Asset Name'
                className='mt-8 border rounded p-4'
                onChange={ e => updateFormInput({...formInput, name: e.target.value})} 
                />
                <textarea
                placeholder='Asset Description'
                className='mt-2 border rounded p-4'
                onChange={ e => updateFormInput({...formInput, description: e.target.value})} 
                />
                <input
                placeholder='Asset Price in Eth'
                className='mt-2 border rounded p-4'
                onChange={ e => updateFormInput({...formInput, price: e.target.value})} 
                />
                <input
                type='file'
                name='Asset'
                className='mt-4'
                onChange={onChange} 
                /> {
                fileUrl && (
                    <img className='rounded mt-4' width='350px' src={fileUrl} />
                )}
                <button onClick={createMarket}
                className='font-bold mt-4 bg-purple-500 text-white rounded p-4 shadow-lg'
                >
                    Mint NFT
                </button>
            </div>
        </div>
    )

}