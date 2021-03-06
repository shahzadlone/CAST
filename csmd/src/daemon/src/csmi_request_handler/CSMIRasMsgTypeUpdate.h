/*================================================================================

    csmd/src/daemon/src/csmi_request_handler/CSMIRasMsgTypeUpdate.h

  © Copyright IBM Corporation 2015-2017. All Rights Reserved

    This program is licensed under the terms of the Eclipse Public License
    v1.0 as published by the Eclipse Foundation and available at
    http://www.eclipse.org/legal/epl-v10.html

    U.S. Government Users Restricted Rights:  Use, duplication or disclosure
    restricted by GSA ADP Schedule Contract with IBM Corp.

================================================================================*/
/*
 * Author: Nick Buonarota
 * Email:  nbuonar@us.ibm.com
 */
 
#ifndef __CSMI_RAS_MSG_TYPE_UPDATE_H__
#define __CSMI_RAS_MSG_TYPE_UPDATE_H__

#include "csmi_stateful_db.h"

class CSMIRasMsgTypeUpdate : public CSMIStatefulDB {

public:
	CSMIRasMsgTypeUpdate(csm::daemon::HandlerOptions &options):CSMIStatefulDB(CSM_CMD_ras_msg_type_update, options)
	{
		
	}
	
	
private:
	// COMPOSE SQL STATEMENT
	// if error occurs when composing a SQL stmt, this call will return false and errcode
	// and errmsg, bool compareDataForPrivateCheckRes=false shall be set with error info
	// note: errcode must be defined in csmi/src/common/include/csmi_cmd_error.h
	virtual bool CreatePayload(
        const std::string& stringBuffer,
        const uint32_t bufferLength,
        csm::db::DBReqContent **dbPayload,
        csm::daemon::EventContextHandlerState_sptr& ctx ) final;

	//DEAL WITH RETURNS FROM SQL QUERY
	virtual bool CreateByteArray(
        const std::vector<csm::db::DBTuple *>&tuples,
        char** stringBuffer, 
		uint32_t &bufferLength,
        csm::daemon::EventContextHandlerState_sptr& ctx ) final;
};
#endif