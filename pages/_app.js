import '../styles/globals.css'
import './app.css'
import Link from 'next/link'

function NFTSupermarket({Component, pageProps}) {
  return (
    <div>
      <nav className='border-b p-6' style={{backgroundColor:'rgb(150,22, 33)'}}>
        <p className='text-4x1 font-bold text-white' style = {{ fontFamily:'monospace'}}>NFT Supermarket</p>
        <div className='flex mt-4 justify-center' style={{fontFamily: 'Roboto'}}>
          <Link href='/'>
            <a className='mr-4'>
                Main
            </a>
          </Link>
          <Link href='/mint-token'>
            <a className='mr-6'>
              Mint Tokens
            </a>
          </Link>
          <Link href='/my-nfts'>
            <a className='mr-6'>
              My NFT
            </a>
          </Link>
          <Link href='/my-create'>
            <a className='mr-6'>
              My Create
            </a>
          </Link>
          </div>
      </nav>
      <Component {...pageProps} />
    </div>
  )
}

export default NFTSupermarket