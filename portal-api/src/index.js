import { env } from "cloudflare:workers";


export default {
async fetch(request) {
const url = new URL(request.url)
const inParamValue1 = url.searchParams.get('inParamValue1') // Get the parameter 1 from the `parameter 1` query parameter
const inParamValue2 = url.searchParams.get('inParamValue2') // Get the parameter 2 from the `parameter 2` query parameter
const base64Credentials = url.searchParams.get('credentials') // Get the CREDENTIALS from the 'credential' query parameter

if (!inParamValue1) {
    return new Response('Missing "inParamValue1" query parameter', { status: 400 })
}
if (!inParamValue2) {
	return new Response('Missing "inParamValue2" query parameter', { status: 400 })
}

if (!base64Credentials) {
    return new Response('Missing "credentials" query parameter', { status: 400 })
}
//authenticate user and get token
try {
let response = await signInUser(atob(base64Credentials).split(":")[0], atob(base64Credentials).split(":")[1])
let data = await response.json()
if(data.error){
	return new Response(data.error.code + " " + data.error.message)
}

//use token to read document to fetch subscriptions
response = await readDocument(data["idToken"],"api","subscriptions")
data = await response.json()
if(data.error){
return new Response(data.error.code + " " + data.error.message)
}
//check if API module exists for user
let modules = data["fields"][atob(base64Credentials).split(":")[0]]["mapValue"]["fields"]["modules"]["arrayValue"]["values"].find(item => item["mapValue"]["fields"]["module"]["stringValue"] === inParamValue2)

//invoke webMethods API if module exists
if(modules){
	response = await webMethods(modules["mapValue"]["fields"]["api"]["stringValue"] + inParamValue1)
	if(response.statusText==="OK"){
		data = await response.json();
	}else{
		return new Response("Error invoking API: " + response.status + " " + response.statusText)
	}
	//client transaction to logs
	//use token to read document to fetch invocations
	response = await readDocument(data["idToken"],"api","invocations")
	data = await response.json()
	if(data.error){
		return new Response(data.error.code + " " + data.error.message)
	}
	//write response back to client
	buildDataLog(data,base64Credentials);
    await writeDocumentLogs(data["idToken"], "api", "invocations", data);
	return new Response(JSON.stringify(data))
} else {
	return new Response("Module not found for user")
}
} catch (error){
	return new Response("An error occurred:",error)
}
}}

async function signInUser(email, password) {
  const url = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${JSON.parse(env.FIRESTORE_CONFIG).api_key}`;
  const requestBody = {
    email: email,
    password: password,
    returnSecureToken: true // Request ID and refresh tokens
  };

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(requestBody)
    });

    return response
  } catch (error) {
    console.error('Network or signin error:', error);
  }
}

async function readDocument(tokenId, collection,documentId) {
  const url = `https://firestore.googleapis.com/v1/projects/${JSON.parse(env.FIRESTORE_CONFIG).project_id}/databases/(default)/documents/${collection}/${documentId}`;
  
  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
		'Authorization': 'Bearer ' + tokenId
      },
    });
    return response
  } catch (error) {
    console.error('Network or read document error:', error);
  }
}

async function writeDocumentLogs(tokenId, collection,documentId,requestBody) {
  const url = `https://firestore.googleapis.com/v1/projects/${JSON.parse(env.FIRESTORE_CONFIG).project_id}/databases/(default)/documents/${collection}/${documentId}?updateMask.fieldPaths=fields.logs`;
  
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
		'Authorization': 'Bearer ' + tokenId
      },
	  body: JSON.stringify(requestBody)
    });
    return response
  } catch (error) {
    console.error('Network or read document error:', error);
  }
}

async function webMethods(url) {  
  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
		'Authorization': 'Basic ' + b64EncodeUnicode(JSON.parse(env.FIRESTORE_CONFIG).username + ':' + JSON.parse(env.FIRESTORE_CONFIG).password)
      },
    });
    return response
  } catch (error) {
    console.error('Network or webMethods error:', error);
  }
}

function b64EncodeUnicode(str) {
  // First, we use encodeURIComponent to get percent-encoded UTF-8,
  // then convert the percent encodings into raw bytes which
  // can be fed into btoa.
  return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
    function toSolidBytes(match, p1) {
		const hexString = '0x' + p1;
		const unicodeValue = parseInt(hexString, 16);
		return String.fromCharCode(unicodeValue);
	      }));
}

function buildDataLog(data,base64Credentials) {
  const today =  new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, "0");
  const day = String(today.getDate()).padStart(2, "0");
  const formattedDate = `${day}-${month}-${year}`;
  let count = data["fields"][atob(base64Credentials).split(":")[0]]["arrayValue"]["values"].find((item)=>item["mapValue"]["fields"][formattedDate])===undefined?0:parseInt(data["fields"][atob(base64Credentials).split(":")[0]]["arrayValue"]["values"].find((item)=>item["mapValue"]["fields"][formattedDate])["mapValue"]["fields"][formattedDate]["stringValue"]) ?? 0;
  
    if(count > 0){
  //find index of item to update
  let updateIndex = data["fields"][atob(base64Credentials).split(":")[0]]["arrayValue"]["values"].findIndex((item)=>item["mapValue"]["fields"][formattedDate])
  data["fields"][atob(base64Credentials).split(":")[0]]["arrayValue"]["values"][updateIndex]["mapValue"]["fields"][formattedDate]= JSON.parse(`{"stringValue": "${(count + 1).toString()}"}`)
  }else{
    //create new invocation
    let test = `{"mapValue":{"fields":{"${formattedDate}":{"stringValue": "1"}}}}`
    
    // to add an item to the items array.
    let jsonArray = data["fields"][atob(base64Credentials).split(":")[0]]["arrayValue"]["values"];
    try{ jsonArray.push(JSON.parse(test))}catch(error){console.log(error)}
   
    console.log(jsonArray)
  }

  return data;
  }


