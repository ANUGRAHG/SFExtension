using sap.sfextension.refapp as refapp from '../db/schema';

service AdminService @(requires : 'authenticated-user') {

    // @topic: 'my/custom/topic'
    // event sfemessage {
    //     message    : String(20);
    //     employeeId : String;
    //     managerId  : String;
    //     readStatus : Boolean;
    // }

    @Capabilities                               : {
        Insertable : true,
        Deletable  : false,
        Updatable  : true
    }
    @Common.SemanticKey                         : [
    ID,
    projectName
    ]
    @Capabilities.SearchRestrictions.Searchable : true
    entity Project as projection on refapp.Project {
        *
    } actions {
        @(
            Common.SideEffects              : {
                EffectTypes      : #ValueChange,
                TargetProperties : [
                criticality,
                status.crticality,
                status.StatusI
                ],
                TargetEntities   : [
                Project,
                Status
                ]
            },
            cds.odata.bindingparameter.name : '_it',
        )
        action ChangeStatus(
        @(
            UI.Hidden : false,
            title     : '{i18n>ChangeStatus}',
            Common    : {
                FieldControl     : #Mandatory,
                ValueListWithFixedValues,
                ValueListMapping : {
                    CollectionPath : 'Status',
                    Parameters     : [
                    {
                        $Type             : 'Common.ValueListParameterInOut',
                        LocalDataProperty : 'criticality',
                        ValueListProperty : 'id',
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'StatusI'
                    }
                    ]
                }
            }
        )
        criticality : String not null);
    };

    @Capabilities                               : {
        Insertable : false,
        Deletable  : true,
        Updatable  : false
    }
    @Capabilities.SearchRestrictions.Searchable : true
    @Common.SemanticKey                         : [
    ID,
    employeeId
    ]
    entity Notifications @(restrict : [{
        grant : 'READ',
        where : 'managerId = $user.id'
    }])            as projection on refapp.Notifications;
}


annotate AdminService.Project with @odata.draft.enabled;
annotate AdminService.Notifications with @odata.draft.enabled;

extend service AdminService with {
    @Common.SemanticKey : [userinfo_employeename]
    entity Mappings as projection on refapp.EmployeeProjectMapping;

    entity Status   as projection on refapp.Status;
}
