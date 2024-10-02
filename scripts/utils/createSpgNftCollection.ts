import 'dotenv/config';
import { StoryClient, StoryConfig } from '@story-protocol/core-sdk'
import { http, Address, Account } from 'viem'
import { privateKeyToAccount } from 'viem/accounts'

const main = async function () {
    const privateKey: Address = `0x${process.env.WALLET_PRIVATE_KEY}`;
    const account: Account = privateKeyToAccount(privateKey)

    const config: StoryConfig = {
        account: account,
        transport: http('https://testnet.storyrpc.io/'),
        chainId: 'iliad',
    }
    const client = StoryClient.newClient(config)

    const newCollection = await client.nftClient.createNFTCollection({
        name: 'Test NFT',
        symbol: 'TEST',
        txOptions: { waitForTransaction: true },
    })

    console.log(
        `New SPG NFT collection created at transaction hash ${newCollection.txHash}`,
        `NFT contract address: ${newCollection.nftContract}`
    )
}

main ()
